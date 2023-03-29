/*
 * Copyright (c) 2011-2023 Contributors to the Eclipse Foundation
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0, or the Apache License, Version 2.0
 * which is available at https://www.apache.org/licenses/LICENSE-2.0.
 *
 * SPDX-License-Identifier: EPL-2.0 OR Apache-2.0
 */
package io.vertx.oracleclient.impl.commands;

import io.vertx.core.Future;
import io.vertx.core.impl.ContextInternal;
import io.vertx.oracleclient.OraclePrepareOptions;
import io.vertx.oracleclient.impl.RowReader;
import io.vertx.sqlclient.PrepareOptions;
import io.vertx.sqlclient.Row;
import io.vertx.sqlclient.Tuple;
import io.vertx.sqlclient.impl.QueryResultHandler;
import io.vertx.sqlclient.impl.command.ExtendedQueryCommand;
import oracle.jdbc.OracleConnection;
import oracle.jdbc.OraclePreparedStatement;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.function.Consumer;
import java.util.stream.Collector;

public class OracleCursorQueryCommand<C, R> extends OracleQueryCommand<C, R> {

  private final String sql;
  private final int fetch;
  private final Tuple params;
  private final PrepareOptions prepareOptions;
  private final Consumer<RowReader<C, R>> store;
  private final Collector<Row, C, R> collector;
  private final QueryResultHandler<R> resultHandler;

  private OracleCursorQueryCommand(OracleConnection oracleConnection, ContextInternal connectionContext, ExtendedQueryCommand<R> cmd, Collector<Row, C, R> collector, Consumer<RowReader<C, R>> store) {
    super(oracleConnection, connectionContext, collector);
    sql = cmd.sql();
    fetch = cmd.fetch();
    params = cmd.params();
    prepareOptions = cmd.options();
    resultHandler = cmd.resultHandler();
    this.collector = collector;
    this.store = store;
  }

  public static <U, V> OracleCursorQueryCommand<U, V> create(OracleConnection oracleConnection, ContextInternal connectionContext, ExtendedQueryCommand<V> cmd, Collector<Row, U, V> collector, Consumer<RowReader<U, V>> store) {
    return new OracleCursorQueryCommand<>(oracleConnection, connectionContext, cmd, collector, store);
  }

  @Override
  protected boolean closeStatementAfterExecute() {
    return false;
  }

  @Override
  protected OraclePrepareOptions prepareOptions() {
    return OraclePrepareOptions.createFrom(prepareOptions);
  }

  @Override
  protected String query() {
    return sql;
  }

  @Override
  protected void fillStatement(PreparedStatement ps, Connection conn) throws SQLException {
    for (int i = 0; i < params.size(); i++) {
      // we must convert types (to comply to JDBC)
      Object value = adaptType(conn, params.getValue(i));
      ps.setObject(i + 1, value);
    }
  }

  @Override
  protected Future<Boolean> doExecute(OraclePreparedStatement ps, boolean returnAutoGeneratedKeys) {
    return executeBlocking(ps::executeQueryAsyncOracle)
      .compose(pub -> first(pub))
      .compose(ors -> executeBlocking(() -> new RowReader<>(connectionContext, collector, ors)))
      .compose(rr -> {
        store.accept(rr);
        return rr.read(fetch).compose(oracleResponse -> {
          oracleResponse.handle(resultHandler);
          return rr.hasMore();
        });
      });
  }
}
